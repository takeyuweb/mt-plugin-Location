<?php
    function smarty_function_mtentrylat($args, &$ctx) {
        $entry = $ctx->stash('entry');
        if ($entry->use_location != 1) {
            return;
        }
        return $entry->lat;
    }
?>