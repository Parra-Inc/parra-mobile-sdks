use crate::{api, auth};

pub async fn execute_login() {
    let result = auth::perform_device_authentication().await;

    match result {
        Ok(credential) => {
            let user = api::get_current_user(&credential).await.unwrap();

            if let Some(email) = user.email {
                println!("Successfully logged in as {}", email)
            } else {
                println!("Successfully logged in")
            }
        }
        Err(error) => {
            eprintln!("Failed to login: {}", error)
        }
    }
}
