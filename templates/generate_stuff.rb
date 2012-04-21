generate('rspec:install')
generate('controller wombats index') # plural
generate('controller welcome index') # singular
generate('integration_test widgets')
generate('mailer Notifications signup')
generate('model thing name:string')
generate('helper things')
generate('scaffold widget name:string category:string instock:boolean foo_id:integer bar_id:integer --force')
generate('observer widget')
generate('scaffold gadget') # scaffold with no attributes
generate('scaffold admin/accounts name:string') # scaffold with nested resource

generate('controller things custom_action')

file "app/views/things/custom_action.html.erb", "This is a template for a custom action.", {:force=>true}

run('rake db:migrate')
run('rake db:test:prepare')
