AM = Artificial.Mummification
RA = Retronator.Accounts

WebApp.connectHandlers.use '/admin/artificial/mummification/documentcaches/documentcaches.json', (request, response, next) ->
  
  try
    exportingDocuments = AM.DocumentCaches._caches[0].getter()

    response.writeHead 200, 'Content-Type': 'application/json'
    response.write JSON.stringify exportingDocuments
    response.end()  # 结束响应

  catch error
    console.error error
    response.writeHead 400, 'Content-Type': 'text/txt'
    response.end "You do not have permission to download document caches."
