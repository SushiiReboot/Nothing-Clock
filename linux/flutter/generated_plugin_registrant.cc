//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <worldtime/worldtime_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) worldtime_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WorldtimePlugin");
  worldtime_plugin_register_with_registrar(worldtime_registrar);
}
