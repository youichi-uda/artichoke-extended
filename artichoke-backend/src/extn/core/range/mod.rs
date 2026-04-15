use std::ffi::CStr;

use crate::extn::prelude::*;

const RANGE_CSTR: &CStr = c"Range";
static RANGE_RUBY_SOURCE: &[u8] = include_bytes!("range.rb");

pub fn init(interp: &mut Artichoke) -> InitializeResult<()> {
    if interp.is_class_defined::<Range>() {
        return Ok(());
    }

    let spec = class::Spec::new("Range", RANGE_CSTR, None, None)?;
    interp.def_class::<Range>(spec)?;
    interp.eval(RANGE_RUBY_SOURCE)?;

    Ok(())
}

#[derive(Debug, Clone, Copy)]
pub struct Range;

#[cfg(test)]
mod tests {
    use crate::test::prelude::*;

    const SUBJECT: &str = "Range";
    const FUNCTIONAL_TEST: &[u8] = include_bytes!("range_functional_test.rb");

    #[test]
    fn functional() {
        let mut interp = interpreter();
        let result = interp.eval(FUNCTIONAL_TEST);
        unwrap_or_panic_with_backtrace(&mut interp, SUBJECT, result);
        let result = interp.eval(b"spec");
        unwrap_or_panic_with_backtrace(&mut interp, SUBJECT, result);
    }
}
