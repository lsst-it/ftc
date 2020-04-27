FTC_VERSION = "0.3.0".freeze

namespace :docker do
  task :build do
    sh "docker build --no-cache -t lsstit/ftc:latest -t lsstit/ftc:#{FTC_VERSION}"
  end
end
