AB = Artificial.Base

class Artificial.Pages
  @addPublicPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.PublicAccess, pageClass
    
  @addAdminPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.AdminAccess, pageClass
    
  constructor: ->
    Artificial.Pages.addPublicPage '/artificial/pyramid/interpolation', Artificial.Pyramid.Pages.Interpolation
    Artificial.Pages.addPublicPage '/artificial/reality/chemistry/materials', Artificial.Reality.Pages.Chemistry.Materials
    Artificial.Pages.addPublicPage '/artificial/reality/chemistry/materials/scattering', Artificial.Reality.Pages.Chemistry.Materials.Scattering
    Artificial.Pages.addPublicPage '/artificial/reality/chemistry/gases', Artificial.Reality.Pages.Chemistry.Gases
    Artificial.Pages.addPublicPage '/artificial/reality/optics/scattering', Artificial.Reality.Pages.Optics.Scattering
    Artificial.Pages.addPublicPage '/artificial/reality/optics/sky', Artificial.Reality.Pages.Optics.Sky
    Artificial.Pages.addPublicPage '/artificial/spectrum/color/chromaticity', Artificial.Spectrum.Pages.Color.Chromaticity
  
    Artificial.Pages.addAdminPage '/admin/artificial/babel', Artificial.Babel.Pages.Admin
    Artificial.Pages.addAdminPage '/admin/artificial/babel/scripts', Artificial.Babel.Pages.Admin.Scripts
    Artificial.Pages.addAdminPage '/admin/artificial/mummification', Artificial.Mummification.Pages.Admin
    Artificial.Pages.addAdminPage '/admin/artificial/mummification/databasecontent', Artificial.Mummification.Pages.Admin.DatabaseContent
    Artificial.Pages.addAdminPage '/admin/artificial/mummification/documentcaches', Artificial.Mummification.Pages.Admin.DocumentCaches
