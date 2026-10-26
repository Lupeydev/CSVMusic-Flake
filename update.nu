
let repo = "angall1/CSVMusic"
let file = "default.nix"

let headers = if ($env.GITHUB_TOKEN? | is-empty) {
  {}
} else {
  { Authorization: $"Bearer ($env.GITHUB_TOKEN)" }
}

let tag = http get --headers $headers $"https://api.github.com/repos/($repo)/releases/latest"
  | get tag_name
let version = $tag | str trim --left --char 'v'

if not ($version =~ '^\d+(\.\d+)+$') {
  error make { msg: $"Unexpected tag format: ($tag)" }
}

let current = open --raw $file
  | parse --regex 'version = "(?<v>[^"]+)";'
  | get 0.v

if $current == $version {
  print $"Already at ($version), nothing to do"
  exit 0
}

print $"Updating ($current) -> ($version)"

let url = $"https://github.com/($repo)/releases/download/($tag)/CSVMusic-linux.zip"
let hash = nix store prefetch-file --json $url | from json | get hash

let updated = open --raw $file
  | str replace --regex 'version = "[^"]+";' $'version = "($version)";'
  | str replace --regex 'hash = "[^"]+";' $'hash = "($hash)";'

if not (($updated | str contains $version) and ($updated | str contains $hash)) {
  error make { msg: "Replacement failed, default.nix layout may have changed" }
}

$updated | save --force $file