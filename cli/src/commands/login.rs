use crate::{api, auth};

pub async fn execute_login() {
    let result = auth::perform_device_authentication().await;

    match result {
        Ok(credential) => {
            let user = api::get_current_user(&credential).await.unwrap();
            println!(
                "Successfully logged in as {}",
                user.email.unwrap_or(user.name)
            )
        }
        Err(error) => {
            eprintln!("Failed to login: {}", error)
        }
    }
}
