use std::error::Error;

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
