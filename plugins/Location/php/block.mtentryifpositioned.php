<?php
    function smarty_block_mtentryifpositioned($args, $content, &$ctx, &$repeat) {
        if (!isset($content)) {
            $entry = $ctx->stash('entry');
            if ($entry->use_location) {
                $flag = 1;
            } else {
                $flag = 0;
            }
            return $ctx->_hdlr_if($args, $content, $ctx, $repeat, $flag);
        } else {
            return $ctx->_hdlr_if($args, $content, $ctx, $repeat);
        }
    }
?>