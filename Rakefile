namespace :docker do
  task :build do
    ftc_version = `git describe --tags`.chomp
    sh "docker build --no-cache -t lsstit/ftc:dev -t lsstit/ftc:#{ftc_version} #{File.dirname(__FILE__)}"
  end

  task :run do
    workingdir = Dir.getwd
    homedir = File.expand_path('~')
    sh "docker run -it --rm" \
        " -v #{workingdir}:/local " \
        " -v #{homedir}/.kube:/root/.kube" \
        " --env-file=#{workingdir}/.env lsstit/ftc:dev"
  end

  task :release do
    ftc_version = `git describe --tags`.chomp
    sh "docker tag lsstit/ftc:#{ftc_version} lsstit/ftc:latest"
    sh "docker push lsstit/ftc:#{ftc_version}"
    sh "docker push lsstit/ftc:latest"
  end
end
