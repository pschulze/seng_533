require "flexo"
require "kemal"
require "uuid"

post "/compare" do |env|
  file_1 = env.params.files["image1"].tempfile
  file_2 = env.params.files["image2"].tempfile
  file_path_1 = ::File.join [Kemal.config.public_folder, "uploads/", File.basename(file_1.path)]
  file_path_2 = ::File.join [Kemal.config.public_folder, "uploads/", File.basename(file_2.path)]

  File.open(file_path_1, "w") do |f|
    IO.copy(file_1, f)
  end
  File.open(file_path_2, "w") do |f|
    IO.copy(file_2, f)
  end

  result = Flexo.compare(file_path_1, file_path_2)
  result_file_uuid = UUID.random.to_s
  result.save(::File.join [Kemal.config.public_folder, "results/", result_file_uuid])

  env.response.content_type = "application/json"
  {score: result.score, comparison_image_path: "https://seng533.pschulze.dev/download/#{result_file_uuid}"}.to_json
end

get "/result/:guid" do |env|
  begin
    result_file_uuid = UUID.new(env.params.url["guid"])
  rescue
    halt env, status_code: 404, response: "Not Found"
  end

  result_file_path = ::File.join [Kemal.config.public_folder, "results/", result_file_uuid]
  unless File.exists?(result_file_path)
    halt env, status_code: 404, response: "Not Found"
  end

  send_file(env, result_file_path)
end

port = ARGV[0]?.try &.to_i?
Kemal.run port
