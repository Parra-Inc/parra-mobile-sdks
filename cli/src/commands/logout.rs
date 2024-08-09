use crate::auth;

pub fn execute_logout() {
    let result = auth::logout();

    match result {
        Ok(success) => {
            if success {
                println!("Successfully logged out.")
            } else {
                println!("Not currently logged in.")
            }
        }
        Err(error) => {
            eprintln!("Failed to logout: {}", error)
        }
    }
}
