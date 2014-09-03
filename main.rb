require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17
POT_AMOUNT = 500

helpers do
  def calculate_total(cards)
    sum = 0
    arr = cards.map { |e| e[1]}

    arr.each do |v|
      if v == "A"
        sum += 11
      elsif v == "J" || v == "Q" || v == "K"
        sum += 10
      else
        sum += v.to_i
      end
    end

    arr.select { |e| e == "A"}.count.times do
     break if sum <= BLACKJACK_AMOUNT
        sum -=10
    end    

   sum

  end
  # calculate_total(session[:dealers_cards]) => 20
  # display images

  def card_image(card) #['H', 4]
    suit = case card[0]
      when 'h' then 'hearts'
      when 'd' then 'diamonds'
      when 'c' then 'clubs'
      when 's' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner!(msg)
    session[:player_pot] += session[:player_bet]
    @show_hit_or_stay_buttons = false
    @winner = "<strong>#{session[:username]} wins!</strong> #{msg} #{session[:username]} now has $#{session[:player_pot]}"
    @play_again = true

  end

  def loser!(msg)
    session[:player_pot] -= session[:player_bet]
    @show_hit_or_stay_buttons = false
    @loser = "<strong>#{session[:username]} loses!</strong> #{msg} #{session[:username]} now has $#{session[:player_pot]}"
    @play_again = true
  end

  def tie!(msg)
    @show_hit_or_stay_buttons = false
    @winner = "<strong>It's a tie!</strong> #{msg} #{session[:username]} now has $#{session[:player_pot]}"
    @play_again = true
  end

end

before do
  @show_hit_or_stay_buttons = true
  @play_again = false
end

get '/' do
  session[:player_pot] = POT_AMOUNT
  erb :form
end

post '/' do
  if params[:username].empty?
    @error = "Name is required"
    halt erb(:form)
  end

  session[:username] = params[:username]
  redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:bet].empty? || params[:bet].to_i <= 0
    @error = "Must make a bet"
    halt erb(:bet)
  elsif params[:bet].to_i > session[:player_pot]
    @error = "Bet amount cannot be greater than $#{session[:player_pot]}."
  else
    session[:player_bet] = params[:bet].to_i
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:username]
  session[:total] = session[:player_pot]
  #set up initial values
  suits = ["s", "d", "c", "h"]
  numbers = ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"]
  session[:deck] = suits.product(numbers).shuffle! # nested array

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  #if you automatically hit blackjack
  if calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    winner!("#{session[:username]} hit blackjack!")
  end

  # render template
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    winner!("#{session[:username]} hit blackjack!")
  elsif calculate_total(session[:player_cards]) > BLACKJACK_AMOUNT
    loser!("Sorry, it looks like #{session[:username]} busted!")
  end

  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "You have chosen to stay."
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'

end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Dealer busted at #{dealer_total}.")
  elsif dealer_total >= DEALER_MIN_HIT
    #dealer stays
    redirect '/game/compare'
  else
    #dealer hits
    @show_dealer_hit_button = true
  end

  erb :game, layout: false
    
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("#{session[:username]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("#{session[:username]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  else
    tie!("Both #{session[:username]} and the dealer stayed at #{player_total}.")
  end
  erb :game
    
end

get '/game_over' do
  erb :game_over
end