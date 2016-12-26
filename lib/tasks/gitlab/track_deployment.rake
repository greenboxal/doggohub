namespace :doggohub do
  desc 'DoggoHub | Tracks a deployment in DoggoHub Performance Monitoring'
  task track_deployment: :environment do
    metric = Gitlab::Metrics::Metric.
      new('deployments', version: Gitlab::VERSION)

    Gitlab::Metrics.submit_metrics([metric.to_hash])
  end
end
