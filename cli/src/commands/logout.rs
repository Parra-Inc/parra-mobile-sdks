use crate::auth;

pub fn execute_logout() {
    let result = auth::logout();

    match result {
        Ok(_) => {
            println!("Successfully logged out")
        }
        Err(error) => {
            eprintln!("Failed to logout: {}", error)
        }
    }
}
