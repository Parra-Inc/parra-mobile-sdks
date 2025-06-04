use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct HexValue {
    pub r#ref: Option<String>,
    pub hex_value: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TransparentColorToken {
    pub transparent: bool,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Token {
    HexValue(HexValue),
    TransparentColorToken(TransparentColorToken),
    PxValue(PxValue),
    RemValue(RemValue),
    Unknown(serde_json::Value),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct PaletteColorSwatch {
    #[serde(rename(deserialize = "50", serialize = "shade_50"))]
    pub shade_50: HexValue,
    #[serde(rename(deserialize = "100", serialize = "shade_100"))]
    pub shade_100: HexValue,
    #[serde(rename(deserialize = "200", serialize = "shade_200"))]
    pub shade_200: HexValue,
    #[serde(rename(deserialize = "300", serialize = "shade_300"))]
    pub shade_300: HexValue,
    #[serde(rename(deserialize = "400", serialize = "shade_400"))]
    pub shade_400: HexValue,
    #[serde(rename(deserialize = "500", serialize = "shade_500"))]
    pub shade_500: HexValue,
    #[serde(rename(deserialize = "600", serialize = "shade_600"))]
    pub shade_600: HexValue,
    #[serde(rename(deserialize = "700", serialize = "shade_700"))]
    pub shade_700: HexValue,
    #[serde(rename(deserialize = "800", serialize = "shade_800"))]
    pub shade_800: HexValue,
    #[serde(rename(deserialize = "900", serialize = "shade_900"))]
    pub shade_900: HexValue,
    #[serde(rename(deserialize = "950", serialize = "shade_950"))]
    pub shade_950: HexValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ResolvedPalette {
    pub white: HexValue,
    pub black: HexValue,
    pub transparent: TransparentColorToken,
    pub red: PaletteColorSwatch,
    pub orange: PaletteColorSwatch,
    pub amber: PaletteColorSwatch,
    pub yellow: PaletteColorSwatch,
    pub lime: PaletteColorSwatch,
    pub green: PaletteColorSwatch,
    pub emerald: PaletteColorSwatch,
    pub teal: PaletteColorSwatch,
    pub cyan: PaletteColorSwatch,
    pub sky: PaletteColorSwatch,
    pub blue: PaletteColorSwatch,
    pub indigo: PaletteColorSwatch,
    pub violet: PaletteColorSwatch,
    pub purple: PaletteColorSwatch,
    pub fuchsia: PaletteColorSwatch,
    pub pink: PaletteColorSwatch,
    pub rose: PaletteColorSwatch,
    pub slate: PaletteColorSwatch,
    pub gray: PaletteColorSwatch,
    pub zinc: PaletteColorSwatch,
    pub neutral: PaletteColorSwatch,
    pub stone: PaletteColorSwatch,
    pub primary: PaletteColorSwatch,
    pub secondary: PaletteColorSwatch,
    pub success: PaletteColorSwatch,
    pub warning: PaletteColorSwatch,
    pub danger: PaletteColorSwatch,
    pub info: PaletteColorSwatch,
    pub tertiary: PaletteColorSwatch,
    pub accent: PaletteColorSwatch,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RemValue {
    pub r#ref: Option<String>,
    pub rem_value: f64,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct PxValue {
    pub r#ref: Option<String>,
    pub px_value: f64,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum FontSizeType {
    #[serde(rename = "xs")]
    Xs,
    #[serde(rename = "sm")]
    Sm,
    #[serde(rename = "md")]
    Md,
    #[serde(rename = "lg")]
    Lg,
    #[serde(rename = "xl")]
    Xl,
    #[serde(rename = "2xl")]
    Xxl,
    #[serde(rename = "3xl")]
    Xxxl,
    #[serde(rename = "4xl")]
    Xxxxl,
    #[serde(rename = "5xl")]
    Xxxxxl,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Ref {
    pub reference: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FontSizes {
    #[serde(rename = "xs")]
    pub xs: PxValue,
    #[serde(rename = "sm")]
    pub sm: PxValue,
    #[serde(rename = "md")]
    pub md: PxValue,
    #[serde(rename = "lg")]
    pub lg: PxValue,
    #[serde(rename = "xl")]
    pub xl: PxValue,
    #[serde(rename = "2xl")]
    pub xxl: PxValue,
    #[serde(rename = "3xl")]
    pub xxxl: PxValue,
    #[serde(rename = "4xl")]
    pub xxxxl: PxValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum FontWeightType {
    #[serde(rename = "light")]
    Light,
    #[serde(rename = "regular")]
    Regular,
    #[serde(rename = "medium")]
    Medium,
    #[serde(rename = "semibold")]
    Semibold,
    #[serde(rename = "bold")]
    Bold,
    #[serde(rename = "extrabold")]
    Extrabold,
    #[serde(rename = "black")]
    Black,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FontWeightToken {
    pub value: f64,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FontWeights {
    pub light: FontWeightToken,
    pub regular: FontWeightToken,
    pub medium: FontWeightToken,
    pub semibold: FontWeightToken,
    pub bold: FontWeightToken,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct LineHeights {
    pub tight: RemValue,
    pub normal: RemValue,
    pub relaxed: RemValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FontFamilyToken {
    pub value: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FontFamilies {
    pub base: FontFamilyToken,
    pub heading: FontFamilyToken,
    pub monospace: FontFamilyToken,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ResolvedTypography {
    pub font_size: FontSizes,
    pub font_weight: FontWeights,
    pub line_height: LineHeights,
    pub font_family: FontFamilies,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum TextTransform {
    #[serde(rename = "none")]
    None,
    #[serde(rename = "uppercase")]
    Uppercase,
    #[serde(rename = "lowercase")]
    Lowercase,
    #[serde(rename = "capitalize")]
    Capitalize,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MarginToken {
    pub px_value: f64,
    pub r#ref: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MarginAll {
    pub all: MarginToken,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MarginEdges {
    pub top: MarginToken,
    pub right: MarginToken,
    pub bottom: MarginToken,
    pub left: MarginToken,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MarginDirectional {
    pub vertical: MarginToken,
    pub horizontal: MarginToken,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", content = "value")]
pub enum Margin {
    MarginToken(MarginToken),
    MarginAll(MarginAll),
    MarginEdges(MarginEdges),
    MarginDirectional(MarginDirectional),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct PaddingToken {
    pub px_value: f64,
    pub r#ref: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct PaddingAll {
    pub all: PaddingToken,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct PaddingEdges {
    pub top: PaddingToken,
    pub right: PaddingToken,
    pub bottom: PaddingToken,
    pub left: PaddingToken,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct PaddingDirectional {
    pub vertical: PaddingToken,
    pub horizontal: PaddingToken,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Padding {
    PaddingToken(PaddingToken),
    PaddingAll(PaddingAll),
    PaddingEdges(PaddingEdges),
    PaddingDirectional(PaddingDirectional),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BackgroundTheme {
    pub primary: HexValue,
    pub secondary: HexValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum BorderStyle {
    #[serde(rename = "solid")]
    Solid,
    #[serde(rename = "dashed")]
    Dashed,
    #[serde(rename = "dotted")]
    Dotted,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum PxValueType {
    #[serde(rename = "none")]
    None,
    #[serde(rename = "sm")]
    Sm,
    #[serde(rename = "md")]
    Md,
    #[serde(rename = "lg")]
    Lg,
    #[serde(rename = "xl")]
    Xl,
    #[serde(rename = "2xl")]
    Xxl,
    #[serde(rename = "full")]
    Full,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BadgeSize {
    pub font_size: RemValue,
    pub padding: Padding,
    pub border_radius: PxValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BadgeBase {
    pub font_size: RemValue,
    pub font_weight: FontWeightToken,
    pub padding: Padding,
    pub border_width: PxValue,
    pub border_radius: PxValue,
    pub background_color: HexValue,
    pub color: HexValue,
    pub border_style: BorderStyle,
    pub border_color: HexValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BadgeVariant {
    pub background_color: HexValue,
    pub color: HexValue,
    pub border_color: HexValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BadgeVariants {
    pub primary: BadgeVariant,
    pub secondary: BadgeVariant,
    pub accent: BadgeVariant,
    pub success: BadgeVariant,
    pub warning: BadgeVariant,
    pub danger: BadgeVariant,
    pub info: BadgeVariant,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BadgeSizes {
    #[serde(rename = "2xs")]
    pub xxs: BadgeSize,
    #[serde(rename = "xs")]
    pub xs: BadgeSize,
    #[serde(rename = "sm")]
    pub sm: BadgeSize,
    #[serde(rename = "md")]
    pub md: BadgeSize,
    #[serde(rename = "lg")]
    pub lg: BadgeSize,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BadgeTheme {
    pub base: BadgeBase,
    pub variants: BadgeVariants,
    pub sizes: BadgeSizes,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CardBase {
    pub background_color: HexValue,
    pub padding: Option<Padding>,
    pub border_width: Option<PxValue>,
    pub border_style: Option<BorderStyle>,
    pub border_color: Option<HexValue>,
    pub border_radius: Option<PxValue>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CardVariant {
    pub background_color: Option<HexValue>,
    pub padding: Option<Padding>,
    pub border_width: Option<PxValue>,
    pub border_style: Option<BorderStyle>,
    pub border_color: Option<HexValue>,
    pub border_radius: Option<PxValue>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CardVariants {
    pub elevated: CardVariant,
    pub outlined: CardVariant,
    pub secondary: CardVariant,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CardTheme {
    pub base: CardBase,
    pub variants: CardVariants,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SeparatorBase {
    pub background_color: HexValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SeparatorTheme {
    pub primary: SeparatorBase,
    pub secondary: SeparatorBase,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ChipBase {
    pub background_color: Option<HexValue>,
    pub color: Option<HexValue>,
    pub border_width: Option<PxValue>,
    pub border_style: Option<BorderStyle>,
    pub border_color: Option<HexValue>,
    pub border_radius: Option<PxValue>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ChipVariant {
    pub background_color: HexValue,
    pub color: HexValue,
    pub border_width: Option<PxValue>,
    pub border_style: Option<BorderStyle>,
    pub border_color: Option<HexValue>,
    pub border_radius: Option<PxValue>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ChipVariants {
    pub primary: ChipVariant,
    pub secondary: ChipVariant,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ChipSize {
    pub font_size: RemValue,
    pub padding: Padding,
    pub border_radius: PxValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ChipSizes {
    pub xs: ChipSize,
    pub sm: ChipSize,
    pub md: ChipSize,
    pub lg: ChipSize,
    pub xl: ChipSize,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ChipTheme {
    pub base: ChipBase,
    pub variants: ChipVariants,
    pub sizes: ChipSizes,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum HeadingTag {
    #[serde(rename = "h1")]
    H1,
    #[serde(rename = "h2")]
    H2,
    #[serde(rename = "h3")]
    H3,
    #[serde(rename = "h4")]
    H4,
    #[serde(rename = "h5")]
    H5,
    #[serde(rename = "h6")]
    H6,
    #[serde(rename = "p")]
    P,
    #[serde(rename = "span")]
    Span,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum TextAlign {
    #[serde(rename = "left")]
    Left,
    #[serde(rename = "center")]
    Center,
    #[serde(rename = "right")]
    Right,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TypographyBase {
    #[serde(rename = "as")]
    pub tag: Option<HeadingTag>,
    pub font_family: Option<FontFamilyToken>,
    pub color: Option<HexValue>,
    pub text_align: Option<TextAlign>,
    pub text_transform: Option<TextTransform>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TypographySize {
    pub font_size: RemValue,
    pub font_weight: FontWeightToken,
    pub line_height: RemValue,
    pub letter_spacing: f64,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TypographySizes {
    #[serde(rename = "xs")]
    pub xs: TypographySize,
    #[serde(rename = "sm")]
    pub sm: TypographySize,
    #[serde(rename = "md")]
    pub md: TypographySize,
    #[serde(rename = "lg")]
    pub lg: TypographySize,
    #[serde(rename = "xl")]
    pub xl: TypographySize,
    #[serde(rename = "2xl")]
    pub xxl: TypographySize,
    #[serde(rename = "3xl")]
    pub xxxl: TypographySize,
    #[serde(rename = "4xl")]
    pub xxxxl: TypographySize,
    #[serde(rename = "5xl")]
    pub xxxxxl: TypographySize,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TypographyVariant {
    pub color: HexValue,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TypographyVariants {
    pub heading: TypographyVariant,
    pub subheading: TypographyVariant,
    pub body: TypographyVariant,
    pub caption: TypographyVariant,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TypographyTheme {
    pub base: TypographyBase,
    pub sizes: TypographySizes,
    pub variants: TypographyVariants,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ResolvedComponents {
    pub background: BackgroundTheme,
    pub badge: BadgeTheme,
    pub card: CardTheme,
    pub chip: ChipTheme,
    pub separator: SeparatorTheme,
    pub typography: TypographyTheme,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ResolvedTheme {
    pub id: String,
    pub design_system_id: String,
    pub name: String,
    pub key: String,
    pub is_dark: bool,
    pub is_default: bool,
    pub palette: ResolvedPalette,
    pub colors: HashMap<String, HexValue>,
    pub typography: ResolvedTypography,
    pub components: ResolvedComponents,
    pub tokens: HashMap<String, Token>,
}
