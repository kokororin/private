import bh_plugin


class SelectAttr(bh_plugin.BracketPluginCommand):
    def run(self, edit, name, direction='right'):
        """
        Select next attribute in the given direction.
        Wrap when the end is hit.
        """

        if self.left.size() <= 1:
            return
        tag_name = r'[\w\:\.\-]+'
        attr_name = r'''([\w\-\.:]+)(?:\s*=\s*(?:(?:"((?:\.|[^"])*)")|(?:'((?:\.|[^'])*)')|([^>\s]+)))?'''
        tname = self.view.find(tag_name, self.left.begin)
        current_region = self.selection[0]
        current_pt = self.selection[0].b
        region = self.view.find(attr_name, tname.b)
        selection = self.selection

        if direction == 'left':
            last = None

            # Keep track of last attr
            if region is not None and current_pt <= region.b and region.b < self.left.end:
                last = region

            while region is not None and region.b < self.left.end:
                # Select attribute until you have closest to the left of selection
                if (
                    current_pt > region.b or
                    (
                        current_pt <= region.b and current_region.a >= region.a and not
                        (
                            region.a == current_region.a and region.b == current_region.b
                        )
                    )
                ):
                    selection = [region]
                    last = None
                # Update last attr
                elif last is not None:
                    last = region
                region = self.view.find(attr_name, region.b)
            # Wrap right
            if last is not None:
                selection = [last]
        else:
            first = None
            # Keep track of first attr
            if region is not None and region.b < self.left.end:
                first = region

            while region is not None and region.b < self.left.end:
                # Select closest attr to the right of the selection
                if(
                    current_pt < region.b or
                    (
                        current_pt <= region.b and current_region.a >= region.a and not
                        (
                            region.a == current_region.a and region.b == current_region.b
                        )
                    )
                ):
                    selection = [region]
                    first = None
                    break
                region = self.view.find(attr_name, region.b)
            # Wrap left
            if first is not None:
                selection = [first]
        self.selection = selection


def plugin():
    return SelectAttr
