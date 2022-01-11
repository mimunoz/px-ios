require 'json'
require 'git_diff_parser'

# Lint
swiftlint.strict = false
swiftlint.max_num_violations = 150
swiftlint.config_file = '.swiftlint.yml'
swiftlint.binary_path = "ExampleSwift/Pods/SwiftLint/swiftlint"

diff = GitDiffParser::Patches.parse(github.pr_diff)
dir = "#{Dir.pwd}/"
swiftlint.lint_files(inline_mode: true) { |violation|
  diff_filename = violation['file'].gsub(dir, '')
  file_patch = diff.find_patch_by_file(diff_filename)
  file_patch != nil && file_patch.changed_lines.any? { |line| line.number == violation['line']}
}

 # Verify if PR title contains Jira task
tickets = github.pr_title.scan(/\[(\w{1,10}-\d+)\]/)
if tickets.empty?
  message('This PR does not include any JIRA tasks in the title. (e.g. [TICKET-1234])')
else
  ticket_urls = tickets.map do |ticket|
    "[#{ticket[0]}](https://mercadolibre.atlassian.net/browse/#{ticket[0]})"
  end
  message("JIRA: " + ticket_urls.join(" "))
end

# Mainly to encourage writing up some reasoning about the PR, rather than just leaving a title
fail "Please, follow the PR template to better document your changes." if github.pr_body.length < 15

# Check if the PR title is in the correct format and changelog entry
title_regex = /\(((Added)|(Fixed)|(Changed)|(Security)|(Deprecated)|(Removed))\)(\[[A-Z]{1,}-\d{1,}\]|()) - \w+/
title_description_split_regex =  /\(((Added)|(Fixed)|(Changed)|(Security)|(Deprecated)|(Removed))\)(\[[A-Z]{1,}-\d{1,}\]|()) - /
title_description = github.pr_title.split(title_description_split_regex).last
tile_is_well_formated = title_regex.match?(github.pr_title) 

if !tile_is_well_formated
  fail "The PR title should follow the title convetion: (Added,Changed,Deprecated,Removed,Fixed,Security)[JIRA-XXX] - (brief description here)"
else 
  has_app_changes = !git.modified_files.grep(/MercadoPagoSDK\/MercadoPagoSDK\//).empty?
  has_title_in_changelog = File.read(“CHANGELOG.md”).include?(title_description)
  if has_app_changes && !has_title_in_changelog
    fail("Please include a [CHANGELOG.md](https://github.com/mercadopago/px-ios/blob/develop/CHANGELOG.md) entry. The changelog entry should be equal to the PR title in the correct section: " + title_description)
  end
end

# Warn when there is a big PR
message "You and the size of your PR are awesome! 🚀" if git.lines_of_code < 500
warn "Big PR, consider splitting into smaller ones." if git.lines_of_code >= 1000

xcov.report(
   scheme: 'ExampleSwift',
   workspace: 'ExampleSwift/ExampleSwift.xcworkspace',
   scheme: 'ExampleSwift',
   minimum_coverage_percentage: 1.0
)