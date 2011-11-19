$ ->
  $('#last_name_input').closest('form').submit (e) ->
    e.preventDefault()
    last_name = $('#last_name_input').val()
    window.location = "#{window.location.protocol}//#{window.location.host}/names/#{last_name.toLowerCase()}"
