generate('rspec:install')
generate('controller wombats index') # plural
generate('controller welcome index') # singular
generate('integration_test widgets')
generate('mailer Notifications signup')
generate('model thing name:string')
generate('helper things')
generate('scaffold widget name:string category:string instock:boolean --force')
generate('observer widget')
generate('scaffold gadget') # scaffold with no attributes
generate('scaffold admin/accounts name:string') # scaffold with nested resource

run('rake db:migrate')
run('rake db:test:prepare')
