# Solidus Packeta

[Packeta](https://www.packeta.com) (Zásilkovna) delivers to pickup points and Z-BOXes. This extension
connects it to Solidus:

- **Pickup points.** Registers Packeta with
  [solidus_pickup_points](https://github.com/zivotsbedou/solidus_pickup_points), so checkout stores
  the point a customer picks in the Packeta widget and accepts only Packeta point IDs.
- **Labels.** A ready Packeta shipment in the legacy admin gets a **Create Packeta label** button.
  It creates the packet through Packeta's API and keeps the packet ID as the shipment's tracking
  number. The label PDF is fetched from Packeta whenever staff open it.
- **Weight from products.** The packet weight is the sum of the shipment's variant weights. A
  product without a weight stops the packet and is named in the message.

A shipment with a tracking number never creates a second packet. If Packeta refuses a packet or does
not answer, the admin shows the reason and the shipment stays as it was.

## Installation

```ruby
gem 'solidus_pickup_points', github: 'zivotsbedou/solidus_pickup_points'
gem 'solidus_packeta', github: 'zivotsbedou/solidus_packeta'
```

```shell
bin/rails generate solidus_packeta:install
```

The generator copies `config/initializers/solidus_packeta.rb` and installs solidus_pickup_points.
Take the API key and API password from the Packeta client section:

```ruby
SolidusPacketa.configure do |config|
  config.api_key = ENV.fetch("PACKETA_API_KEY", nil)            # public, for the widget
  config.api_password = ENV.fetch("PACKETA_API_PASSWORD", nil)  # server only
  config.sender = ENV.fetch("PACKETA_SENDER", nil)              # needed with more than one sender

  config.carrier = "packeta"         # shipping method carrier with service level "pickup"
  config.weight_unit = "kg"          # unit of your variant weights: kg, g, lb or oz
  config.label_format = "A6 on A6"   # any Packeta label format
end
```

Create a shipping method with that carrier and the service level `pickup`. Set its tracking URL to
`https://tracking.packeta.com/cs/?id=:tracking` so the shipped e-mail links Packeta's tracking.

## Storefront

Load the [Packeta widget](https://docs.packeta.com/docs/pudo-delivery/widget) with
`SolidusPacketa.config.api_key` and fill the solidus_pickup_points fields from its callback:
`pickup_point_id` from `point.id`, `pickup_name` from `point.name` and `pickup_address` from the
point's street, ZIP and city.

## Development

```shell
bin/rake          # builds spec/dummy on the first run, then runs the specs
bundle exec rubocop
```

## License

Copyright (c) 2026 Život s Béďou, z.s., released under the BSD 3-Clause License.
