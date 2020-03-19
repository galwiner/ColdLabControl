path = getCurrentSaveFolder;
FolderName = [path, '\..\SavedFigs'];   % Your destination folder
if ~exist(FolderName,'dir')
    mkdir(FolderName)
end
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = get(FigHandle, 'Name');
  if isempty(FigName)
      FigName = num2str(FigHandle.Number);
  end
  savefig(FigHandle, fullfile(FolderName, [FigName '.fig']));
end
