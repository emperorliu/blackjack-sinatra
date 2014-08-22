require 'rubygems'
require 'sinatra'

set :sessions, true

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
     break if sum <= 21
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

    "<img src='images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

end

before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  erb :form
end

post '/' do
  if params[:username].empty?
    @error = "Name is required"
    halt erb(:form)
  end

  session[:username] = params[:username]
  redirect '/game'
end

get '/game' do
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

  # render template
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) == 21
    @success = "Congrats! You hit Blackjack!"
    @show_hit_or_stay_buttons = false
  elsif calculate_total(session[:player_cards]) > 21
    @error = "Sorry, it looks like you busted."
    @show_hit_or_stay_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
  @success = "You have chosen to stay."
  @show_hit_or_stay_buttons = false
  # redirect '/game/dealer'
  erb :game

end

# get '/game/dealer' do
#   @show_hit_or_stay_buttons = false

#   dealer_total = calculate_total(session[:dealer_cards])
#   if dealer_total == 21
#     @error = "Sorry, dealer hit blackjack."
#   elsif dealer_total > 21
#     @success = "Congraulations, dealer busted. You win"
#   elsif dealer_total >= 17
#     #dealer stays
#     redirect '/game/compare'
#   else
#     #dealer hits
#     @show_dealer_hit_button = true
#   end

#   erb :game
    
# end

# post '/game/dealer/hit' do
#   session[:dealer_cards] << session[:deck].pop
#   redirect '/game/dealer'
# end

# get '/game/compare' do
#   player_total = calculate_total(session[:player_cards])
#   dealer_total = calculate_total(session[:dealer_cards])

#   if player_total < dealer_total
#     @error = "sorry, you lost."
#   elsif player_total > dealer_total
#     @success = "Congrats, you won!"
#   else
#     @success = "It's a tie!"

#   erb :game
    
# end
