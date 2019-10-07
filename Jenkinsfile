pipeline {
	agent { node 'xcode' }

	stages {

		stage('Checkout and Setup') {
			steps {
				checkout([
					$class: 'GitSCM',
					branches: scm.branches,
					doGenerateSubmoduleConfigurations: false,
					extensions: scm.extensions + [[$class: 'SubmoduleOption', disableSubmodules: false, recursiveSubmodules: true, reference: '', trackingSubmodules: false]],
					submoduleCfg: [],
					userRemoteConfigs: scm.userRemoteConfigs
				])

				sh 'brew bundle'
				sh 'rbenv install -s && rbenv local'
				sh 'gem install bundler && bundle update'
			}
		}

		stage('Build & Test') {
			steps {
				sh 'bundle exec fastlane test'
			}
			post {
				always {
					checkstyle pattern: 'output/swiftlint.xml'
					junit 'output/tests/report.junit'
					publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: true, reportDir: 'output/tests', reportFiles: 'report.html', reportName: 'Unit Tests Report', reportTitles: 'tests'])
					publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: true, reportDir: 'output/coverage', reportFiles: 'index.html', reportName: 'XCov Report', reportTitles: 'xcov'])
				}
				success {
					archiveArtifacts artifacts:'output/MiKee.*'
				}
			}
		}

		stage('Deployment') {
			when {
				expression { env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'develop' }
			}

			parallel {

				stage('Beta') {
					when {
						expression { return env.BRANCH_NAME == 'develop' }
					}
					steps {
						sh 'bundle exec fastlane beta'
					}
				}

				stage('AppStore') {
					when {
						expression { return env.BRANCH_NAME == 'master' }
					}
					steps {
						sh 'bundle exec fastlane release'
					}
					post {
						success {
							publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: true, reportDir: 'output/screenshots', reportFiles: 'screenshots.html', reportName: 'Screenshots', reportTitles: 'screenshots'])
						}
					}
				}
			}
		}
  	}
}
