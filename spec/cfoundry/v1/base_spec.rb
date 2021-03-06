require "spec_helper"

describe CFoundry::V1::Base do
  let(:base) { CFoundry::V1::Base.new("https://api.cloudfoundry.com") }

  describe '#get' do
    let(:options) { {} }
    subject { base.get("foo", options) }

    context 'when successful' do
      context 'and the accept type is JSON' do
        let(:options) { {:accept => :json} }

        it 'returns the parsed JSON' do
          stub_request(:get, 'https://api.cloudfoundry.com/foo').to_return :status => 201, :body => "{\"hello\": \"there\"}"
          expect(subject).to eq(:hello => "there")
        end
      end

      context 'and the accept type is not JSON' do
        let(:options) { {:accept => :form} }

        it 'returns the body' do
          stub_request(:get, 'https://api.cloudfoundry.com/foo').to_return :status => 201, :body =>  "body"
          expect(subject).to eq "body"
        end
      end
    end

    context 'when an error occurs' do
      let(:response_code) { 404 }

      it 'raises the correct error if JSON is parsed successfully' do
        stub_request(:get, 'https://api.cloudfoundry.com/foo').to_return :status => response_code,
          :body =>  "{\"code\": 111, \"description\": \"Something bad happened\"}"
        expect {subject}.to raise_error CFoundry::SystemError, "111: Something bad happened"
      end

      it 'raises the correct error if code is missing from response' do
        stub_request(:get, 'https://api.cloudfoundry.com/foo').to_return :status => response_code,
          :body =>  "{\"description\": \"Something bad happened\"}"
        expect {subject}.to raise_error CFoundry::NotFound
      end

      it 'raises the correct error if response body is not JSON' do
        stub_request(:get, 'https://api.cloudfoundry.com/foo').to_return :status => response_code,
          :body =>  "Error happened"
        expect {subject}.to raise_error CFoundry::NotFound
      end

      it 'raises a generic APIError if code is not recognized' do
        stub_request(:get, 'https://api.cloudfoundry.com/foo').to_return :status => response_code,
          :body =>  "{\"code\": 6932, \"description\": \"Something bad happened\"}"
        expect {subject}.to raise_error CFoundry::APIError, "6932: Something bad happened"
      end
    end
  end
end
