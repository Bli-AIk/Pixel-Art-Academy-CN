Package.describe({
  name: 'retronator:pixelartacademy-practice',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'quill-delta': '4.2.2',
  'path-data-polyfill': '1.0.4'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions-assets');
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-learning');
  api.use('retronator:pixelartdatabase');
  api.use('froatsnook:request');

  api.use('jparker:crypto-aes');

  api.export('PixelArtAcademy');

  api.addFile('practice');

  // Journal

  api.addFile('journal..');
  api.addFile('journal/methods');
  api.addServerFile('journal/subscriptions');

  api.addFile('journal/entry..');
  api.addFile('journal/entry/methods');
  api.addServerFile('journal/entry/subscriptions');
  api.addFile('journal/entry/action');
  api.addFile('journal/entry/avatar');

  // Pages

  api.addFile('pages/pages');

  api.addUnstyledComponent('pages/admin..');
  api.addUnstyledComponent('pages/admin/scripts..');
  api.addServerFile('pages/admin/scripts/methods-server/convertcheckins');

  // Check-ins (legacy)

  api.addFile('checkin/checkin');
  api.addFile('checkin/methods');
  api.addServerFile('checkin/methods-server');
  api.addServerFile('checkin/subscriptions');
  api.addServerFile('checkin/migrations/0000-renamecollection');
  api.addServerFile('checkin/migrations/0001-characterreferencefieldsupdate');
  api.addServerFile('checkin/migrations/0002-removecharacternamefield');
  api.addServerFile('checkin/migrations/0003-changetomemories');

  api.addFile('importeddata/importeddata');
  api.addServerFile('importeddata/checkin-server/checkin');
  api.addServerFile('importeddata/checkin-server/migrations/0000-renamecollection');

  api.addUnstyledComponent('pages/extractimagesfromposts/extractimagesfromposts');
  api.addServerFile('pages/extractimagesfromposts/methods-server');

  api.addComponent('pages/importcheckins/importcheckins');
  api.addServerFile('pages/importcheckins/methods-server');

  // Project

  api.addFile('project..');
  api.addServerFile('project/subscriptions');

  api.addFile('project/thing');
  api.addFile('project/workbench');
  api.addFile('project/asset');

  api.addFile('project/assets/bitmap..');
  api.addComponent('project/assets/bitmap/portfoliocomponent..');
  api.addComponent('project/assets/bitmap/clipboardcomponent..');
  api.addUnstyledComponent('project/assets/bitmap/briefcomponent..');

  // Challenges

  api.addFile('challenges..');
  api.addFile('challenges/drawing..');

  // Tutorials

  api.addFile('tutorials..');
  api.addFile('tutorials/drawing..');
  api.addFile('tutorials/drawing/tutorial');

  api.addFile('tutorials/drawing/assets..');

  api.addFile('tutorials/drawing/assets/tutorialbitmap..');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/tutorialbitmap-create');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/tutorialbitmap-reset');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/enginecomponent');
  api.addUnstyledComponent('tutorials/drawing/assets/tutorialbitmap/briefcomponent..');

  api.addFile('tutorials/drawing/assets/vectortutorialbitmap..');
  api.addFile('tutorials/drawing/assets/vectortutorialbitmap/vectortutorialbitmap-create');
  api.addFile('tutorials/drawing/assets/vectortutorialbitmap/vectortutorialbitmap-reset');
  api.addFile('tutorials/drawing/assets/vectortutorialbitmap/path');
  api.addFile('tutorials/drawing/assets/vectortutorialbitmap/enginecomponent');
  api.addUnstyledComponent('tutorials/drawing/assets/vectortutorialbitmap/briefcomponent..');

  // Software
  api.addFile('software..');
  api.addFile('software/tools');

  // Artworks
  api.addFile('artworks..');
  api.addFile('artworks/methods');
});
