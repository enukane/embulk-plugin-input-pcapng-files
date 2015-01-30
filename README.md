embulk-plugin-input-pcapng-files
================================

Embulk plugin for pcapng files input.


To extract specific field from pcapng files

1. check sample\_config.yml, modify "paths" to where ever pcapng files are.
2. specify fields to collect in "schema", name should correspond to tshark's field name


## BUGs

- ~~"done" list is not properly handled~~
  - fixed (2015/01/29) thanks to frsyuki

### ToDo

- Obviously, most part duplicates to file input.
  - rewrite this as decoder or parser plugin?
  - after it become capable to write parser plugin in ruby
