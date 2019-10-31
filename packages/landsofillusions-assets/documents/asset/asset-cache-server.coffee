AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Assets.Asset extends AM.Document
  @Meta: (meta) ->
    super arguments...

    return if meta.abstract

    cache = null
    cacheBuildId = null
    
    cachableDocumentsQuery =
      authors:
        $exists: false
    
    Meteor.startup =>
      Tracker.autorun =>
        # Invalidate cache on document changes.
        LOI.Assets[@className].documents.find(cachableDocumentsQuery).observeChanges
          added: -> cache = null
          changed: -> cache = null
          removed: -> cache = null

      WebApp.connectHandlers.use @cacheUrl(), (request, response, next) =>
        unless cache
          # Rebuild cache.
          cache = {}

          assets = LOI.Assets[@className].documents.fetch cachableDocumentsQuery,
            # Do not send history in cache.
            fields:
              history: false
              historyPosition: false

          for asset in assets
            cache[asset._id] = asset

          cache = JSON.stringify cache
          cacheBuildId = Random.id()

        # See if client's cache is up to date.
        if request.headers['if-none-match'] is cacheBuildId
          # The client already has the right cache, all is good.
          response.writeHead 304

        else
          # Send the cache content to the client.
          response.writeHead 200,
            'Content-Type': 'application/json'
            'Cache-Control': 'public, max-age=0'
            'ETag': cacheBuildId

          response.write cache

        response.end()
