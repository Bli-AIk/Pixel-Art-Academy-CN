AM = Artificial.Mirage
AMu = Artificial.Mummification

class AMu.Pages.Admin.DocumentCaches extends AM.Component
  @id: -> 'Artificial.Mummification.Pages.Admin.DocumentCaches'
  @register @id()

  events: ->
    super(arguments...).concat
      'click .download-button': @onClickDownloadButton

  onClickDownloadButton: (event) ->
    password = @$('.password').val()

    userId = CryptoJS.AES.encrypt(Meteor.userId(), password).toString()

    $link = $('<a style="display: none">')
    $('body').append $link

    link = $link[0]
    link.download = 'documentcaches.json'
    link.href = "/admin/artificial/mummification/documentcaches/documentcaches.json?userId=#{encodeURIComponent userId}"
    link.click()

    $link.remove()
