fetch:
	# "assuming you are on host computer, not rivanna"
	# "also assuming you are in WSL if on windows host computer"
	# "also assuming that you have rivanna alias set up in ssh config"
	#
	#
	#
	mkdir -p data
	# scp rivanna:/project/bii_dsc_community/dje5dj/gregor/scratch/thf2bn/mlcommons/benchmarks/cloudmask/target/rivanna
	rsync -r -R --no-i-r --include="*/" --include="*.out" --include="*.yaml" --exclude="*" --info=progress2 --prune-empty-dirs rivanna:/project/bii_dsc_community/dje5dj/gregor/scratch/thf2bn/mlcommons/benchmarks/cloudmask/target/rivanna/ data
	cp -r data/project/bii_dsc_community/dje5dj/gregor/scratch/thf2bn/mlcommons/benchmarks/cloudmask/target/rivanna/* data/
	rm -rf data/project

