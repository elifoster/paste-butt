Gem::Specification.new do |s|
  s.authors = ['Eli Foster']
  s.name = 'pastee'
  s.version = '3.0.0'
  s.summary = 'A simple interface to the paste.ee API'
  s.description = 'Accessing the paste.ee simply through Ruby. Has full ' \
                  'support for all of their custom errors.'
  s.email = 'elifosterwy@gmail.com'
  s.homepage = 'https://github.com/elifoster/pasteee-rb'
  s.license = 'MIT'
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/elifoster/pastee-rb/issues',
    'changelog_uri' => 'https://elifoster.github.io/pastee-rb/file.CHANGELOG.html',
    'documentation_uri' => 'https://elifoster.github.io/pastee-rb',
    'source_code_uri' => 'https://github.com/elifoster/pastee-rb'
  }
  s.files = [
    'lib/pastee.rb',
    'lib/pastee/errors.rb',
    'lib/pastee/paste.rb',
    'lib/pastee/syntax.rb',
    'CHANGELOG.md'
  ]
  s.add_runtime_dependency('httpclient', '~> 2.8')
end
