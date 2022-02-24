fileId=$(curl -sb -H -u "$SAUCELABS_USERNAME:$SAUCELABS_ACCESS_KEY" --location \
--request POST 'https://api.us-west-1.saucelabs.com/v1/storage/upload' \
--form 'payload=@"../build/ExampleSwift.ipa"' \
--form 'name="ExampleSwift.ipa"' | json item.id) 
envman add --key SAUCELABS_FILE_ID_UPLOADED --value $fileId
