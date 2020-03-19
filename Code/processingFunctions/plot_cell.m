function plot_cell(array_of_plots)
figure;
gca
hold on
for ii = 1:length(array_of_plots)
   plot(array_of_plots{ii})
end
end