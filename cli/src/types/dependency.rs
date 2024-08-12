use core::fmt;

#[derive(Copy, Clone)]
pub struct SemanticVersion {
    pub major: u8,
    pub minor: u8,
    pub patch: u8,
}

impl fmt::Debug for SemanticVersion {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Version: {}.{}.{}", self.major, self.minor, self.patch)
    }
}
