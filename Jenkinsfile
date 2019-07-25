#! /usr/bin/env groovy

pipeline {
  agent { label 'docker' }

  stages {
    stage('Build') {
      steps {
        sh 'docker build -t academic_benchmarks .'
      }
    }
    stage('Test') {
      steps {
        sh """
          docker run --rm \
            -e ACADEMIC_BENCHMARKS_RUN_LIVE=0 \
            -e ACADEMIC_BENCHMARKS_PARTNER_ID=empty \
            -e ACADEMIC_BENCHMARKS_PARTNER_KEY=empty \
            academic_benchmarks bundle exec rspec
        """
      }
    }
  }
}
