use serde_json::to_string_pretty;
use std::{
    error::Error,
    fs::{self, read_to_string},
    path::{Path, PathBuf},
};
use walkdir::WalkDir;

/// Recursively iterates over all the files in the `target_dir`. Read the contents of
/// each file, apply a template based on the `context`, and write the result back over
/// top of the input file. Only files with a `.liquid` extension suffix will be modified.
/// All other files will be left as-is.
pub fn render_templates_in_dir(
    target_dir: &PathBuf,
    globals: &liquid::Object,
) -> Result<(), Box<dyn Error>> {
    let json_string = to_string_pretty(&globals).unwrap();

    println!("Rendering template with globals: {}", json_string);

    for entry in WalkDir::new(target_dir) {
        match entry {
            Ok(entry) => {
                println!("Processing: {:?}", entry.file_name().to_str());

                if entry.file_type().is_file()
                    && entry.file_name().to_str().unwrap().contains(".liquid")
                {
                    println!(
                        "Applying template to: {}",
                        entry.path().display()
                    );

                    let template = read_to_string(entry.path())?;

                    let rendered_template =
                        render_template(&template, &globals)?;

                    let output_path = remove_liquid_extension(entry.path())?;

                    fs::remove_file(entry.path())?;
                    fs::write(output_path, rendered_template)?;
                }
            }
            Err(err) => {
                eprintln!("Error reading entry: {}", err);
                continue; // Skip to the next iteration
            }
        }
    }

    return Ok(());
}

pub fn render_template(
    template: &str,
    globals: &liquid::Object,
) -> Result<String, Box<dyn Error>> {
    let template = liquid::ParserBuilder::with_stdlib()
        .build()
        .unwrap()
        .parse(&template)
        .unwrap();

    let result = template.render(&globals)?;

    Ok(result)
}

fn remove_liquid_extension(path: &Path) -> Result<PathBuf, Box<dyn Error>> {
    if let Some(str_path) = path.to_str() {
        let without_liquid = str_path.replace(".liquid", "");

        println!("Writing to: {}", without_liquid);

        return Ok(PathBuf::from(without_liquid));
    }

    return Err("Failed to remove suffix".into());
}
