use crate::extn::prelude::*;

static NET_HTTP_RUBY_SOURCE: &[u8] = include_bytes!("vendor/net_http.rb");

pub fn init(interp: &mut Artichoke) -> InitializeResult<()> {
    interp.def_rb_source_file("net/http", NET_HTTP_RUBY_SOURCE)?;
    interp.def_rb_source_file("net/http.rb", NET_HTTP_RUBY_SOURCE)?;
    Ok(())
}
