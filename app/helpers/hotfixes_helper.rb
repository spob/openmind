module HotfixesHelper

  def releases_path
    "#{h @product.svn_path}/Tags/Releases"
  end

  def release
    "#{releases_path}/#{h @source_tag}"
  end

  def hf_tag
    "#{h @release_number} HotFix #{ h @hotfix_number } #{h @defect}"
  end

  def branch
    "#{h @product.svn_path}/Branches/#{hf_tag}"
  end

  def hf_release
    "#{releases_path}/#{hf_tag}"
  end

  def copy_command
    " svn copy \"#{release}\" \"#{branch}\" -m \"Creating branch for #{h @defect} on #{@product.name}#{@release_number}.\"\r svn delete \"#{branch}/Media\" -m \"Remove the Media subfolder in preparation for the hotfix.\"\r svn mkdir \"#{branch}/Media\" -m \"Recreate Media directory in the branch\"\r"
  end
end
