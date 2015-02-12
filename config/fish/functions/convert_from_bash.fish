function convert_from_bash
	sed -e 's/export \(.*\)=\(.*\)/setenv \1 \2/g'
end
