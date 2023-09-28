require 'rspec'
require_relative '../src/rental'
require_relative '../src/commission'
require_relative '../main'

require 'json'

RSpec.describe Main do
  let(:main) { Main.new }

  describe "#process" do
    it "generates the expected output JSON file" do
      main.process

      output_contents = File.read('data/output.json')
      expected_contents = File.read('data/expected_output.json')

      output_json = JSON.parse(output_contents)
      expected_json = JSON.parse(expected_contents)

      expect(output_json).to eq(expected_json)
    end
  end
end
