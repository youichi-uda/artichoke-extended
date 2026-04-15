use crate::extn::prelude::*;

static FILE_RUBY_SOURCE: &[u8] = include_bytes!("vendor/file.rb");

pub fn init(interp: &mut Artichoke) -> InitializeResult<()> {
    interp.def_rb_source_file("file", FILE_RUBY_SOURCE)?;
    Ok(())
}
