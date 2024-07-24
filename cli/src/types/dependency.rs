use core::fmt;

#[derive(Copy, Clone)]
pub struct XcodeVersion {
    pub major: u8,
    pub minor: u8,
    pub patch: u8,
}

impl fmt::Debug for XcodeVersion {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "Xcode version: {}.{}.{}",
            self.major, self.minor, self.patch
        )
    }
}
