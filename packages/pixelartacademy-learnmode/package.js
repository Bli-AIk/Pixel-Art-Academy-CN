Package.describe({
  name: 'retronator:pixelartacademy-learnmode',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');

  api.export('PixelArtAcademy');

  api.addFile('pixelartacademy');
  api.addFile('learnmode');

  api.addComponent('app');

  api.addFile('layouts/layouts');
  api.addUnstyledComponent('layouts/publicaccess/publicaccess');
});
