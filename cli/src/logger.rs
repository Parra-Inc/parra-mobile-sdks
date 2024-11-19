#[macro_export]
macro_rules! debug_println {
    ($($arg:tt)*) => (
        if ::std::cfg!(debug_assertions) {
            ::std::println!($($arg)*);
        }
    )
}

pub(crate) use debug_println;
