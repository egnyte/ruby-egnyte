module Egnyte
 class FolderStructure
    def self.traverse_dfs(folder, session, order=:preorder, max_depth=nil, current_depth=1, &block)
      yield folder if order == :preorder
      folder.folders = folder.folders.each do |f|
        f = Egnyte::Folder.find(session, f.path)
        traverse_dfs(f, session, order, max_depth, current_depth+1, &block) unless !max_depth.nil? and current_depth >= max_depth 
        f
      end
      yield folder if order == :postorder
    end
  end
end