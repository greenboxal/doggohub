module API
  class Version < Grape::API
    before { authenticate! }

    desc 'Get the version information of the DoggoHub instance.' do
      detail 'This feature was introduced in DoggoHub 8.13.'
    end
    get '/version' do
      { version: Gitlab::VERSION, revision: Gitlab::REVISION }
    end
  end
end
