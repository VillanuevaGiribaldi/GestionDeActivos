import { createTheme } from "@mui/material/styles";

const theme = createTheme({
    components: {
        MuiTable: {
            defaultProps: {
                stickyHeader: true,
                size: "small",
            },
        },
        MuiTableRow: {
            styleOverrides: {
                root: {
                    "&:nth-of-type(odd)": {
                        backgroundColor: "#F5F7FA",
                    },
                    "&:nth-of-type(even)": {
                        backgroundColor: "#FFFFFF",
                    },
                    "&:hover": {
                        outline: "2px solid #0D47A1",
                        outlineOffset: "-2px",
                    },
                },
            },
        },
    },
});

export default theme;