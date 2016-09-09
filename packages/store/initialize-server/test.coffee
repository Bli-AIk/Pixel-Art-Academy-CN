RA = Retronator.Accounts
RS = Retronator.Store

# Debug users creation.
Meteor.startup ->
  # Don't do this on production server.
  return unless Meteor.settings.test

  # Kickstarter backers with normal tiers
  createKickstarterBacker 'basic@backer.com', 10, 10, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.BasicGame
  createKickstarterBacker 'full@backer.com', 20, 20, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.FullGame
  createKickstarterBacker 'alpha@backer.com', 40, 40, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AlphaAccess

  # Kickstarter backers with early bird tiers
  createKickstarterBacker 'fullearly@backer.com', 15, 15, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.EarlyFullGame
  createKickstarterBacker 'alphaearly@backer.com', 35, 35, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.EarlyAlphaAccess

  # Kickstarter backers that overpledged
  createKickstarterBacker 'fullover@backer.com', 30, 20, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.FullGame

  # Kickstarter backers that didn't select a reward
  createKickstarterBacker 'no1@backer.com', 1, 0, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward
  createKickstarterBacker 'no10@backer.com', 10, 0, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward
  createKickstarterBacker 'no20@backer.com', 20, 0, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward
  createKickstarterBacker 'no30@backer.com', 30, 0, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward
  createKickstarterBacker 'no40@backer.com', 40, 0, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward
  createKickstarterBacker 'no100@backer.com', 100, 0, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward

createKickstarterBacker = (email, amount, price, tier) ->
  # First check if we already have the user.
  user = Meteor.users.findOne 'emails.address': email
  return if user

  # Get item to add.
  kickstarterItem = RA.Transactions.Item.documents.findOne catalogKey: tier
  console.log kickstarterItem, tier

  # Add a kickstarter payment.
  paymentId = RA.Transactions.Payment.documents.insert
    type: RA.Transactions.Payment.Types.KickstarterPledge
    amount: amount
    project: RA.Transactions.Payment.Projects.PixelArtAcademy

  # Add a transaction for this user's item.
  RA.Transactions.Transaction.documents.insert
    time: new Date()
    email: email
    items: [
      item:
        _id: kickstarterItem._id
      price: price
    ]
    payments: [
      _id: paymentId
    ]

  # Everything went OK, create the user.
  Accounts.createUser email: email, password: 'test'
