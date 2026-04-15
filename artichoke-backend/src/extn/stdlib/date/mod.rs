use std::ffi::CStr;

use crate::extn::prelude::*;

const DATE_CSTR: &CStr = c"Date";
static DATE_RUBY_SOURCE: &[u8] = include_bytes!("vendor/date.rb");

pub fn init(interp: &mut Artichoke) -> InitializeResult<()> {
    interp.def_rb_source_file("date", DATE_RUBY_SOURCE)?;
    interp.def_rb_source_file("date.rb", DATE_RUBY_SOURCE)?;
    Ok(())
}
