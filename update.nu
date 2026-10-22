let version = http get https://api.github.com/repos/angall1/CSVMusic/releases/latest 
| get tag_name 
| str replace 'v' ''

let url = $"https://github.com/angall1/CSVMusic/releases/download/v($version)/CSVMusic-linux.zip"

let hash = nix-prefetch-url $url --type sha256
| nix hash convert --hash-algo sha256 $in

cat ./default.nix
| split row "\""
| update 3 $version
| update 7 $hash
| str join "\""
| save default.nix -f