require "kemal"

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

  "Upload ok"
end

Kemal.run
