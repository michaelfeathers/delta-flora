

require 'code_event'

describe CodeEvent do

  it 'parses method names' do
    CodeEvent.new({ :method_name => "RegisterController::index"}).class_name.should eq('RegisterController')
  end

end
