$(document).ready(function() {
  $('#player_color').click(function(){
    $('#player_cards').css('background-color', 'yellow')
    return false;
  });

  $(document).on("click", "form#hit input", function(){
    alert("player hits!");

    $.ajax({
      type: "POST",
      url: "/game/player/hit"
    }).done(function(msg){
      $('#game').replaceWith(msg)
    });

    return false;
  });

  $(document).on("click", "form#stay input", function(){
    alert("player stays!");

    $.ajax({
      type: "POST",
      url: "/game/player/stay"
    });.done(function(msg){
      $('#game').replaceWith(msg)
    });

    return false;
  });

});